From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [AX.25 1/2] Introduce struct ax25_sock.
Date: Fri, 21 Jul 2006 14:26:26 -0300
Message-ID: <39e6f6c70607211026i4f1df82s80e1bf54eff8a108@mail.gmail.com>
References: <20060721152946.GA16317@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:37666 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751086AbWGUR01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 13:26:27 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1376988ugc
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2006 10:26:26 -0700 (PDT)
To: "Ralf Baechle" <ralf@linux-mips.org>
In-Reply-To: <20060721152946.GA16317@linux-mips.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/21/06, Ralf Baechle <ralf@linux-mips.org> wrote:

> Aside of wanrouter AX.25 has also been the last member of struct
> sock.sk_protinfo.  With net/wanrouter being considered hopeless code and
> an application-level solution being prefered these days this means we now
> can delete sk_protinfo.

/me sheds a tear... ;) Yay, hasta la vista sk_protinfo, it has been a
long way 8)

- Arnaldo
