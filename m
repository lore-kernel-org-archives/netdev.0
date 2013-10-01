From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 2/2] net, mellanox mlx4 Fix compile warnings [v4]
Date: Tue, 01 Oct 2013 11:25:28 -0400
Message-ID: <524AE968.608@redhat.com>
References: <1380633877-24034-1-git-send-email-prarit@redhat.com>	<1380633877-24034-2-git-send-email-prarit@redhat.com> <20131001181742.72e603d1@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, amirv@mellanox.com,
	davem@davemloft.net, ogerlitz@mellanox.com
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab3JAPZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 11:25:39 -0400
In-Reply-To: <20131001181742.72e603d1@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/2013 11:17 AM, Jack Morgenstein wrote:
> Since we are in the middle of submitting patches which touch the file
> "resource_tracker.c", I would really like to hold off on these warning
> fixes for a bit, and I'll handle the changes for all the functions at
> once to conform (correctly!) to the format suggested by Dave Miller.
> 
>  -Jack

Hey Jack, np.  Thanks for looking.

P.
