From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER
 from hw_features
Date: Thu, 12 Mar 2015 08:16:57 -0700
Message-ID: <5501ADE9.8080507@redhat.com>
References: <20150311030305.1337.10832.stgit@ahduyck-vm-fedora20>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E576A1@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E576A1@BPXM14GP.gisp.nec.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


On 03/11/2015 11:00 PM, Hiroshi Shimamoto wrote:
>> Subject: [PATCH] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER from hw_features
>>
>> This change makes it so that the HW_VLAN_STAG_FILTER bit is not falsely
> s/STAG/CTAG/ right?
>
> thanks,
> Hiroshi
>

Yeah, I I'm not sure where the S came from.  Maybe I was looking at 
something else when I was typing.

I'll submit a v2 with updated patch comments.

- Alex

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
