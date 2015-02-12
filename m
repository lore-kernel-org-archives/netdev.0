From: nick <xerofoify@gmail.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware
 Unit Hang"
Date: Wed, 11 Feb 2015 20:18:46 -0500
Message-ID: <54DBFF76.9070100@gmail.com>
References: <1719052.SGOfRAJhfQ@storm>	<1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>	<1421333953.2632.22.camel@jtkirshe-mobl>
	<2609782.Mryft1leMQ@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <2609782.Mryft1leMQ@storm>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On 2015-02-11 06:23 AM, Thomas Jarosch wrote:
> Hi Jeff,
> 
> On Thursday, 15. January 2015 06:59:13 Jeff Kirsher wrote:
>>> Sure, you basically reverted my patch.
>>>
>>> You are not the first to report a problem caused by this patch.
>>>
>>> This patch is known to have uncovered some driver bugs.
>>>
>>> We are not going to revert it. We are going to fix the real bugs.
>>>
>>> Thanks
>>
>> Agreed, we are looking into issue Thomas.
> 
> any news from the Intel labs what might be going on here?
> 
> We started seeing those hangs on "MSI B85M ECO" boards, too,
> though it's way more sporadic there.
> 
> Thanks,
> Thomas
> 
> 
> ------------------------------------------------------------------------------
> Dive into the World of Parallel Programming. The Go Parallel Website,
> sponsored by Intel and developed in partnership with Slashdot Media, is your
> hub for all things parallel software development, from weekly thought
> leadership blogs to news, videos, case studies, tutorials and more. Take a
> look and join the conversation now. http://goparallel.sourceforge.net/
> _______________________________________________
> E1000-devel mailing list
> E1000-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/e1000-devel
> To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
> 
Jeff and Thomas,
I am unable to find the commit id in my email box for the git bisected commit. Would someone send me the commit id so I can look into starting to solve the bugs 
the commit discussed here as uncovered in the driver supported by Intel.
Thanks A lot,
Nick 

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
