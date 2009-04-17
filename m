From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: e1000 watchdog timer fails to start after ethool settings change
Date: Fri, 17 Apr 2009 06:21:35 -0700
Message-ID: <9ae48b020904170621p113400c2hc3d7984469128325@mail.gmail.com>
References: <1239857869.31663.29.camel@localhost.localdomain>
	 <alpine.WNT.2.00.0904160921570.732@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, david.graham@intel.com
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f160.google.com ([209.85.217.160]:63156 "EHLO
	mail-gx0-f160.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847AbZDQNVi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 09:21:38 -0400
Received: by gxk4 with SMTP id 4so1889857gxk.13
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 06:21:36 -0700 (PDT)
In-Reply-To: <alpine.WNT.2.00.0904160921570.732@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 9:43 AM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> I've got to think some on how to fix this and I hope to have a patch =
in
> the next few days. =A0Would you agree not very high priority?

I've worked around the problem, and it seems unlikely to affect many
other people.

> Why it doesn't occur on real physical hardware will be interesting to=
 find
> out as well.

Have you verified this on real hardware?

--Ed
