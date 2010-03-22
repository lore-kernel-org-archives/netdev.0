From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15571] New: TCP madness - some packets are
 shunned.
Date: Mon, 22 Mar 2010 14:37:11 -0700
Message-ID: <20100322143711.b78c7a93.akpm@linux-foundation.org>
References: <bug-15571-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jasen@treshna.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56252 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755575Ab0CVVie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 17:38:34 -0400
In-Reply-To: <bug-15571-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 18 Mar 2010 02:46:29 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15571
> 
>                URL: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=53646
>                     2
>            Summary: TCP madness - some packets are shunned.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: jasen@treshna.com
>         Regression: No
> 
> 
> The host http://www.cv-it.com is virtually unreachable with kernel 2.6.26 
> (and later) slow with kernel 2.6.18 and just fine with windows XP.
> 
> I used telnet to port 80 for testing.
> 
> it seems to be a TCP issue, as the having the XP machine behind a linux based
> iptables firewall pc causes no problems, but telnet from the firewall pc itself
> to port 80 on www.cv-it.com does not work


