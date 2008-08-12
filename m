From: John Patrick Poet <john@blueskytours.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Tue, 12 Aug 2008 15:44:04 -0600
Message-ID: <200808121544.04932.john@blueskytours.com>
References: <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <ec7e30370808112242y4be0ba5fy6d3567e0dc49b6fd@mail.gmail.com> <20080812201847.GA1582@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Madsen <david.madsen@gmail.com>,
	John P Poet <jppoet@gmail.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat1.blueskytours.com ([65.121.119.145]:30148 "HELO
	volcano.blueskytours.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1751116AbYHLVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 17:50:46 -0400
In-Reply-To: <20080812201847.GA1582@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 August 2008 02:18:47 pm Francois Romieu wrote:
> David Madsen <david.madsen@gmail.com> :
> [...]
>
> > I also have a Realtek GigE card that was quite stable running on
> > 2.6.24.  I recently updated my kernel briefly to 2.6.25.10 then
> > ultimately to 2.6.26.2 and started seeing similar timeouts in both
> > kernel versions.
>
> Please note that the kernel complains more loudly about the watchdog
> than it used to. Does it allow traffic to flow afterwards ?

When one of these "hick-ups" happen while I am streaming video from my Myth 
backend to my Myth frontend, it kills the playback, and I have to re-start 
it.  It takes 5 to 10 seconds before I can re-start the playback, but it does 
work without having to take any special action on my part.

So, to answer your question, yes traffic does flow afterwards.

John

