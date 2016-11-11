From: Vladis Dronov <vdronov@redhat.com>
Subject: Re: BUG() can be hit in tcp_collapse()
Date: Fri, 11 Nov 2016 08:08:09 -0500 (EST)
Message-ID: <1716309808.12143903.1478869689618.JavaMail.zimbra@redhat.com>
References: <1623420310.11961160.1478789246631.JavaMail.zimbra@redhat.com> <1478792652.8455.3.camel@edumazet-glaptop3.roam.corp.google.com> <1478805992.8455.20.camel@edumazet-glaptop3.roam.corp.google.com> <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com> <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
        Marco Grassi <marco.gra@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric,

> Another sk_filter() is used in tcp v6.
> So the correct patch would be :

Thank you much for your research. I'm happy my report
has resulted as the proposed patch.

Best regards,
Vladis Dronov | Red Hat, Inc. | Product Security Engineer
