From: Stuart Peloquin <peloquin@MIT.EDU>
Subject: Re: Bug report for MV643XX driver
Date: Wed, 9 Aug 2006 10:57:11 -0400
Message-ID: <200608091057.11665.peloquin@mit.edu>
References: <200608091047.28571.peloquin@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mlachwani@mvista.com, netdev@vger.kernel.org, josejx@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:32478 "EHLO
	biscayne-one-station.mit.edu") by vger.kernel.org with ESMTP
	id S1751276AbWHIRa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 13:30:29 -0400
To: dale@farnsworth.org
In-Reply-To: <200608091047.28571.peloquin@mit.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry,  the revised URL is http://web.mit.edu/peloquin/www/marvell/

On Wednesday 09 August 2006 10:47, Stuart Peloquin wrote:
> Kernel oops during heavy load downloads with the MV643XX driver on a PegII.
> I've replicated the problem on 2.6.17_gentoo-4, vanilla 2.6.17.1, vanilla
> 2.6.18_rc3.  When downloading a large file from any fast mirror (I tested
> getting around 2.0MB/s) the system crashes after a random amount of time.
> Usually after 30seconds to a couple of minutes.
>
> I took pictures of the call trace, I'm sorry about the quality, they were
> taken with a phone camera.  They can be viewed at
> http://web.mit.edu/peloquin/marvell
>
> Thanks,
> -Stuart
