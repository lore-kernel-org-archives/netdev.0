From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Tue, 8 Jul 2014 10:41:27 -0400
Message-ID: <20140708144127.GB23026@hmsreliant.think-freely.org>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
 <20140708111408.GA23026@hmsreliant.think-freely.org>
 <53BBFAA6.80408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35097 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbaGHOli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 10:41:38 -0400
Content-Disposition: inline
In-Reply-To: <53BBFAA6.80408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2014 at 04:05:26PM +0200, Daniel Borkmann wrote:
> On 07/08/2014 01:14 PM, Neil Horman wrote:
> ...
> >since you're adding cmsg's from rfc6458, do you also want to add some
> >deprecation warnings around the use of SCTP_SNDRCVINFO too, so we can start to
> >schedule its eventual removal?
> 
> Sure, we can do that. Do you want me to include it into the set?
> 

If you're plan is to implement 6458, then yes, I think that would be good.
Neil
