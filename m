From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH 01/24] net: rbridge: add trill frame description
Date: Wed, 24 Sep 2014 10:01:06 -0700
Message-ID: <CAHA+R7MQSPMs=aJTP=B=XRtENGa1e2sJT=AthrPy6kZpwCyQRg@mail.gmail.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
	<1411573940-14079-2-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, william@gandi.net,
	f.cachereul@alphalink.fr, Emmanuel Hocdet <manu@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:50137 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaIXRBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:01:08 -0400
Received: by mail-la0-f53.google.com with SMTP id ge10so10845512lab.40
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:01:06 -0700 (PDT)
In-Reply-To: <1411573940-14079-2-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 8:51 AM, Ahmed Amamou <ahmed@gandi.net> wrote:
> diff --git a/include/linux/if_trill.h b/include/linux/if_trill.h
> new file mode 100644
> index 0000000..ad9c631
> --- /dev/null
> +++ b/include/linux/if_trill.h

Keep it in include/net/ directory unless you plan to use it for non-networking,
I don't think this is case here.
