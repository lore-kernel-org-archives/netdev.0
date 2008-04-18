From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 15:09:36 -0300
Message-ID: <9bfa9ae0804181109h711d0c48v9b2d3319cfca7657@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804181919.17456.mb@bu3sch.de>
	 <9bfa9ae0804181043v60b7c92boef1c025ce04cfe37@mail.gmail.com>
	 <200804181959.58607.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:13439 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759445AbYDRSJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 14:09:37 -0400
Received: by yw-out-2324.google.com with SMTP id 5so455742ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 11:09:36 -0700 (PDT)
In-Reply-To: <200804181959.58607.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 2:59 PM, Michael Buesch <mb@bu3sch.de> wrote:
>  > b44_poll: istat = 0x00000400
>
>  Hm, a descriptor error. Smells like my DMA fix actually broke this, damit.
>  On which architecture are you running?

i386 here.

>  > I have increased the delay now.  This is the first message that
>  > appears. It seems that after some time it starts to display the other
>  > lines from my last email (Pid 4, comm: ksoftirqd/0 ...).
>
>  I'm always only interested in the first message of one type :)

Right :-)

Best regards,
Nelson
