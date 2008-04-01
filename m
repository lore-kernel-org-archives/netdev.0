From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 1 Apr 2008 11:33:02 -0700
Message-ID: <200804011133.03333.inaky@linux.intel.com>
References: <200804011107.38563.inaky@linux.intel.com> <20080401111802.65fe259f@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5877 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752672AbYDAShv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 14:37:51 -0400
In-Reply-To: <20080401111802.65fe259f@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 April 2008, Stephen Hemminger wrote:
> On Tue, 1 Apr 2008 11:07:37 -0700
> Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> 
> > 
> > Intel would like to announce the initial release of a Linux WiMAX 
> > common stack and drivers for its WiMAX devices (eg: Intel(r) 
> > WiMAX/WiFi Link 5050, with estimated availability around third 
> > quarter of 2008).
> > 
> > ...
> 
> Code review occurs on patch submittable not by pointing developers off
> to an external project. Most likely there will be feedback that requires
> changes to API and other choices so you want to do this soon.

I know. Just wanted to get out the bits ASAP for whoever is interested to
start looking at it.

I am pondering how to do this because there is a lot of code and 
I still don't have it ready for merging to mainline. 

Eventually I'll have a git tree branching off netdev and will have to break 
up the kernel part in patchbombs for review & submission and fix stuff as 
we go.

Thanks,
