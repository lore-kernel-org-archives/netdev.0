From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: Re: veths often slow to come up
Date: Thu, 6 Aug 2015 08:09:03 +0000
Message-ID: <D1E8D3E9.3FACB%Shaun.Crampton@metaswitch.com>
References: <D1E67FCC.3FA19%Shaun.Crampton@metaswitch.com>
 <CAM_iQpV6ZjKWmy8ou6xM=fP8gfE19cS9r=YT4P2xW7rBJwAyZA@mail.gmail.com>
 <20150805152358.GE10686@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805152358.GE10686@indiana.gru.redhat.com>
Content-Language: en-US
Content-ID: <A76DBBF1F65B6742A2A8EB81926661A8@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Take a look at linkwatch_urgent_event at net/core/link_watch.c, and a=
ll
>of
> link_watch.c in general. That's where the 1s delay comes from.

Thanks for the diagnosis, I=B9ll take a look.

-Shaun
