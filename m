From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Fri, 9 Jun 2006 12:34:50 +0200
Message-ID: <200606091234.50874.rjw@sisk.pl>
References: <44886381.9050506@goop.org> <200606082240.31473.rjw@sisk.pl> <4488D565.2020103@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:34948 "EHLO ogre.sisk.pl")
	by vger.kernel.org with ESMTP id S965015AbWFIKec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 06:34:32 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <4488D565.2020103@goop.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 June 2006 03:56, Jeremy Fitzhardinge wrote:
> Rafael J. Wysocki wrote:
> > Please try doing "echo 8 > /proc/sys/kernel/printk" before suspend.
> >   
> Um, why?  That would increase the amount of log output, but I don't see 
> how it would help with netconsole preventing suspend, or not being able 
> to see console messages on a blank screen after resume.

Ah, that's after resume.  Sorry for the noise. :-)

Rafael
