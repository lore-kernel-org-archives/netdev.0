From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 0/7] sctp: support sctp_diag in kernel
Date: Thu, 7 Apr 2016 15:34:22 -0300
Message-ID: <20160407183422.GG15005@localhost.localdomain>
References: <cover.1459829123.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbcDGSeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 14:34:25 -0400
Content-Disposition: inline
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 12:06:25PM +0800, Xin Long wrote:
> This patchset will add sctp_diag module to implement diag interface on
> sctp in kernel.
...

Other than the const thing and the point noticed by Neil which need
to be fixed, patchset looks good to me.

  Marcelo
