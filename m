From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Tue, 08 Jul 2014 16:05:26 +0200
Message-ID: <53BBFAA6.80408@redhat.com>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com> <20140708111408.GA23026@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430AbaGHOFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 10:05:44 -0400
In-Reply-To: <20140708111408.GA23026@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2014 01:14 PM, Neil Horman wrote:
...
> since you're adding cmsg's from rfc6458, do you also want to add some
> deprecation warnings around the use of SCTP_SNDRCVINFO too, so we can start to
> schedule its eventual removal?

Sure, we can do that. Do you want me to include it into the set?
