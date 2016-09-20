From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH next 2/2] sctp: make use of WORD_TRUNC macro
Date: Tue, 20 Sep 2016 18:20:21 -0300
Message-ID: <20160920212021.GC9323@localhost.localdomain>
References: <cover.1474402102.git.marcelo.leitner@gmail.com>
 <44d3d3e5e0be1f4e557893f1dd8bcc38fae009fa.1474402102.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51100 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752344AbcITVUY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 17:20:24 -0400
Content-Disposition: inline
In-Reply-To: <44d3d3e5e0be1f4e557893f1dd8bcc38fae009fa.1474402102.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 05:24:20PM -0300, Marcelo Ricardo Leitner wrote:
> +	max_data = SCTP_TRUNC4(max_data);

Will post a v2 to fix the subject.
