#!/bin/sh
# usage: mkaddon.sh MyAddOn

if [ $# -ne 1 ]; then
	echo "usage: $0 AddOnName"
	exit 1
fi

ADDON=$1
SLUG=`echo $ADDON | tr [:upper:] [:lower:]`

if [ -e $ADDON ]; then
	echo "directory $ADDON exists. refusing to generate the code."
	exit 2
fi

mkdir $ADDON/
mkdir $ADDON/Controller
mkdir $ADDON/views


cat > $ADDON/Controller/$ADDON.php <<EOF
<?php

namespace $ADDON\Controller;

# custom modules documentation: https://getcockpit.com/docs#!modules/custom
# css framework and icons: https://getuikit.com/v2/docs/icon.html

class $ADDON extends \Cockpit\Controller {

	public function index() {
		\$test = 123;
		return \$this->render('$SLUG:views/index.php', get_defined_vars());
	}

	public function func1() {
		\$test = 777;
		return \$this->render('$SLUG:views/index.php', get_defined_vars());
	}

}
EOF


cat > $ADDON/admin.php <<EOF
<?php

// ACL
\$app('acl')->addResource('$ADDON', ['manage.permissionA', 'manage.permissionB']);

\$app->on("admin.init", function () {
		# check access rights
		if (!\$this->module('auth')->hasaccess('$ADDON', ['create.permissionA', 'edit.permissionA'])) {
			return;
		}

		# bind the controller
		\$this->bindClass('$ADDON\\Controller\\$ADDON', '$SLUG');

		# add an icon to the top bar
		\$this('admin')->menu('top', [
				'url'    => \$this->routeUrl('/$SLUG'),
				'label'  => '<i class="uk-icon-cog"></i>',
				'title'  => \$this('i18n')->get('$ADDON'),
				'active' => (strpos(\$this['route'], '/$SLUG') === 0)
			], -1
		);# 5 is left, -1 is right

		# handle global search request
		\$this->on('cockpit.globalsearch', function (\$search, \$list) {

				if (stripos('search', \$search) !== false) {
					\$list[] = [
						'title' => '<i class="uk-icon-cog"></i> $ADDON',
						'url'   => \$this->routeUrl('/$SLUG'),
					];
				}
			}
		);

	}
);

\$app->on('admin.dashboard.aside', function () {

		# check access rights
		if (!\$this->module('auth')->hasaccess('$ADDON', ['manage.permissionA', 'manage.permissionB'])) {
			return;
		}

		\$title = \$this('i18n')->get('$ADDON');
		//    \$badge = \$this->db->getCollection("common/forms")->count();
		//    \$forms = \$this->db->find("common/forms", ["limit"=> 3, "sort"=>["created"=>-1] ])->toArray();

		\$this->renderView('$SLUG:views/aside.php with cockpit:views/layouts/dashboard.widget.php', get_defined_vars());
	}
);
EOF


cat > $ADDON/views/aside.php <<EOF
<div class="uk-text-center">
	<h2><i class="uk-icon-cog"></i></h2>
	<p class="uk-text-muted">
		@lang('Something…')
	</p>

	@hasaccess?("Nico1", 'manage.permissionA')
		<a href="@route('/$SLUG')" class="uk-button uk-button-success" title="@lang('Something')"
			data-uk-tooltip="{pos:'bottom'}"><i class="uk-icon-plus-circle"></i>
		</a>
	@end
</div>
EOF


cat > $ADDON/views/index.php <<EOF
<div data-ng-controller="backups" ng-cloak>

	<nav class="uk-navbar uk-margin-large-bottom">
		<span class="uk-navbar-brand"><a href="@route('/$SLUG')">@lang('$ADDON')</a></span>
	</nav>


	<div class="uk-grid" data-uk-grid-margin>

		<div class="uk-width-medium-2-3">

			<div class="app-panel">

                <p>
                    Lorem {{ \$test }} ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
                    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
                    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
                    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
                    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
                    proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                </p>
			</div>
		</div>
		<div class="uk-width-medium-1-3">
            <a href="@route('/$SLUG/func1')" class="uk-button uk-button-large uk-button-primary">Function #1</a>
		</div>

	</div>

</div>
EOF


cat > $ADDON/bootstrap.php <<EOF
<?php

// ADMIN
if (COCKPIT_ADMIN && !COCKPIT_REST) {
	include_once (__DIR__ .'/admin.php');
}
EOF


cat > $ADDON/module.json <<EOF
{
	"name": "$ADDON",
	"version": "1.0",
	"description": "This is $ADDON.",
	"homepage": "https://maxdoom.com/",
	"check_url": null,
	"repo": null
}
EOF
