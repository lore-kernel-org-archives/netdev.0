From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 5/5]: act_api: mark some functions static/remove
	unused function
Date: 04 Nov 2004 08:56:42 -0500
Message-ID: <1099576602.1039.151.camel@jzny.localdomain>
References: <4189CB70.3060703@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4189CB70.3060703@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-04 at 01:25, Patrick McHardy wrote:
> Mark some functions static in act_api. 

All the rest of the static conversions are good except for this.

> tc_lookup_action_id was unused
> so I removed it.

Please dont. I am incrementally submitting patches.

cheers,
jamal
