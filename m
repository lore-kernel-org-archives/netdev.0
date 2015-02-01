From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v3 0/3] net-timestamp: blinding
Date: Sun, 1 Feb 2015 12:29:31 +0100
Message-ID: <20150201112931.GA4323@localhost.localdomain>
References: <1422642573-6126-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, luto@amacapital.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:47068 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbbBAL3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 06:29:37 -0500
Received: by mail-wi0-f179.google.com with SMTP id l15so10171976wiw.0
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2015 03:29:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1422642573-6126-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2015 at 01:29:30PM -0500, Willem de Bruijn wrote:
> Two issues were raised during recent timestamping discussions:
> 1. looping full packets on the error queue exposes packet headers
> 2. TCP timestamping with retransmissions generates many timestamps

For the series,

Acked-by: Richard Cochran <richardcochran@gmail.com>
