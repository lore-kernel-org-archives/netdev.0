From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 0/7] wireless: Use macros from wireless.h
Date: Thu, 18 Mar 2010 09:21:53 -0700
Message-ID: <1268929313.4005.9.camel@jlt3.sipsolutions.net>
References: <cover.1268892663.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Richard Kennedy <richard@rsk.demon.co.uk>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pavel Roskin <proski@gnu.org>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	Corey Thomas <coreythomas@charter.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268892663.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-03-17 at 23:21 -0700, Joe Perches wrote:
> Move the STD_IW_HANDLER macro from orinoco to wireless.h
> Use the wireless.h macros in various wireless files
> Remove local #defines of IW_IOCTL

I really don't want to debug any breakage here, but otherwise I don't
care and this is fine with me.

johannes
