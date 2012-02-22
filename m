From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Wed, 22 Feb 2012 09:20:56 -0800
Message-ID: <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
References: <bug-42809-100@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: darkbasic@linuxsystems.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48150 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559Ab2BVRVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 12:21:03 -0500
In-Reply-To: <bug-42809-100@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2012 10:24:19 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=42809
> 
>            Summary: kernel panic when receiving an ipsec packet
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.54
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: darkbasic@linuxsystems.it
>         Regression: No
> 
> 
> As soon as I receive an ipsec packet (NETKEY of course) I get a kernel panic.
> Even magicsysrq keys do not work anymore.
> 
> O.S. Debian Squeeze amd64. I tried both Strongswan and Openswan.
> 

That is a really old kernel now. Could you try with later kernel?
