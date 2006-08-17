From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH][RFC][RESEND] remove broken URLs from net drivers' output
Date: Thu, 17 Aug 2006 13:03:39 +0200
Message-ID: <9a8748490608170403q43a26768y7f789b2b67d10409@mail.gmail.com>
References: <20060817093053.GA13992@fh-brandenburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:62344 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964799AbWHQLDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 07:03:41 -0400
Received: by nf-out-0910.google.com with SMTP id n15so1038790nfc
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 04:03:39 -0700 (PDT)
To: "Markus Dahms" <dahms@fh-brandenburg.de>
In-Reply-To: <20060817093053.GA13992@fh-brandenburg.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/08/06, Markus Dahms <dahms@fh-brandenburg.de> wrote:
> Remove broken URLs (www.scyld.com) from network drivers' logging output.
> URLs in comments and other strings are left intact.
>
Makes good sense to me.
No point in refering to URLs that are no longer operational.
The best thing would be to find a replacement URL if one exist, but
failing that removing the wrong ones is a good thing IMHO.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
