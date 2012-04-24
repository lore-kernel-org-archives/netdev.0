From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: BCM5720
Date: Tue, 24 Apr 2012 13:06:54 -0700
Message-ID: <20120424200654.GB7395@mcarlson.broadcom.com>
References: <CAF2d9jgpfV4rod95LdhicyO5bD_9Umsnhev+UwaT03EMyJGxug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	linux-netdev <netdev@vger.kernel.org>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4434 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757378Ab2DXUHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 16:07:34 -0400
In-Reply-To: <CAF2d9jgpfV4rod95LdhicyO5bD_9Umsnhev+UwaT03EMyJGxug@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 24, 2012 at 01:00:12PM -0700, Mahesh Bandewar wrote:
> Hi,
> 
> The PCI device ID for this was removed sometime in the past. Was there any
> reason behind this (am I missing anything)?

The device ID that was removed was for a preproduction device that was
never released.  There now exists a new device under the same name, but
it has a different device ID.  If you have a BCM5720 device, it should
work with the latest kernels.
