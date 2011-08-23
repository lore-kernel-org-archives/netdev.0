From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 40572] New: Intel Gigabit
 Ethernet 82576 50% packet loss after reboot
Date: Tue, 23 Aug 2011 14:30:53 -0700
Message-ID: <20110823143053.832c1aaa.akpm@linux-foundation.org>
References: <bug-40572-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vojcik@gmail.com, bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-40572-10286@https.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 5 Aug 2011 07:07:05 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=40572
> 
>            Summary: Intel Gigabit Ethernet 82576 50% packet loss after
>                     reboot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: vojcik@gmail.com
>         Regression: No

I'll change this to "yes".

> 
> Hi, 
> 
> I have strange problem with Intel dualport Gigabit ehternet card.
> Problem appears after 3rd - 5th reboot.
> 
> If you ping or make any network traffic you get 50% packet loss. No error
> messages in logs.
> When you make reboot all is ok in next few reboots.
> 
> We have eliminated network problems like switches, cables etc. It's software
> related.
> 
> It looks like in kernel 2.6.37 we have the same problem but in 2.6.28.6
> everything looks fine.
> 
> I attach some files for additional information
> 


------------------------------------------------------------------------------
EMC VNX: the world's simplest storage, starting under $10K
The only unified storage solution that offers unified management 
Up to 160% more powerful than alternatives and 25% more efficient. 
Guaranteed. http://p.sf.net/sfu/emc-vnx-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
