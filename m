From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Thu, 15 Dec 2011 08:46:55 -0800
Message-ID: <EDC0E76513226749BFBC9C3FB031318F018669B7BB@orsmsx508.amr.corp.intel.com>
References: <cover.1323744724.git.richardcochran@gmail.com>
	<388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
	<1323901989.19702.12.camel@jbrandeb-mobl2>
	<20111215161256.GA5176@cherladcori01>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>, Stultz <john.stultz@linaro.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, John
To: Richard Cochran <richardcochran@gmail.com>, "Brandeburg, Jesse"
	<jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20111215161256.GA5176@cherladcori01>
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



>-----Original Message-----
>From: Richard Cochran [mailto:richardcochran@gmail.com]
>Sent: Thursday, December 15, 2011 8:13 AM
>To: Brandeburg, Jesse
>Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Keller,
>Jacob E; Kirsher, Jeffrey T; Ronciak, John; John Stultz; Thomas
>Gleixner; Wyborny, Carolyn
>Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock
>instead of the timecompare method
>
>On Wed, Dec 14, 2011 at 02:33:09PM -0800, Jesse Brandeburg wrote:
>> On Mon, 2011-12-12 at 19:00 -0800, Richard Cochran wrote:
>> > This commit removes the legacy timecompare code from the igb driver
>and
>> > offers a tunable PHC instead.
>> >
>> > Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>>
>> Richard, first, thanks for this work, I have some feedback and request
>> you make a V2.
>
>Thanks for your feedback, I'll will work your comments in.
>
>Any chance of getting the driver tested on a 82576?
>
>Thanks,
>
>Richard

I will request this testing and let you know.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation




------------------------------------------------------------------------------
10 Tips for Better Server Consolidation
Server virtualization is being driven by many needs.  
But none more important than the need to reduce IT complexity 
while improving strategic productivity.  Learn More! 
http://www.accelacomm.com/jaw/sdnl/114/51507609/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
