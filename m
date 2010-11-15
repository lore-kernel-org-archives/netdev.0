From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: Re: [PATCH 14/44] drivers/net/ixgbe: Remove
	unnecessary semicolons
Date: Mon, 15 Nov 2010 08:24:22 -0800
Message-ID: <43F901BD926A4E43B106BF17856F0755013080DEFF@orsmsx508.amr.corp.intel.com>
References: <cover.1289789604.git.joe@perches.com>
	<7d2c334daa75c5221946a17d45c9de1901cf06e7.1289789604.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Jiri Kosina <trivial@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7d2c334daa75c5221946a17d45c9de1901cf06e7.1289789604.git.joe@perches.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Sunday, November 14, 2010 7:05 PM
> To: Jiri Kosina
> Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
> Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P;
> Duyck, Alexander H; Ronciak, John; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH 14/44] drivers/net/ixgbe: Remove unnecessary semicolons
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ixgbe/ixgbe_sriov.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_sriov.c
> b/drivers/net/ixgbe/ixgbe_sriov.c
> index 5428153..93f40bc 100644
> --- a/drivers/net/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ixgbe/ixgbe_sriov.c
> @@ -68,7 +68,7 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter
> *adapter,
>  	 * addresses
>  	 */
>  	for (i = 0; i < entries; i++) {
> -		vfinfo->vf_mc_hashes[i] = hash_list[i];;
> +		vfinfo->vf_mc_hashes[i] = hash_list[i];
>  	}
> 
>  	for (i = 0; i < vfinfo->num_vf_mc_hashes; i++) {
> --
> 1.7.3.1.g432b3.dirty

Acked By: Greg Rose <Gregory.v.rose@intel.com>


------------------------------------------------------------------------------
Centralized Desktop Delivery: Dell and VMware Reference Architecture
Simplifying enterprise desktop deployment and management using
Dell EqualLogic storage and VMware View: A highly scalable, end-to-end
client virtualization framework. Read more!
http://p.sf.net/sfu/dell-eql-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
