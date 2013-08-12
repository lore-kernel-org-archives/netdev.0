From: Jesse Gross <jesse@nicira.com>
Subject: Re: Where are OVS VXLAN patches?
Date: Mon, 12 Aug 2013 09:59:29 -0700
Message-ID: <CAEP_g=-JQUZaLUhkMWQ6p8iYn8jqb_0tZOq=x+kv0Xip3dUA7A@mail.gmail.com>
References: <1376291275.17589.18.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:47848 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756865Ab3HLQ7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 12:59:52 -0400
Received: by mail-la0-f42.google.com with SMTP id mf11so4971320lab.1
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 09:59:51 -0700 (PDT)
In-Reply-To: <1376291275.17589.18.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 12:07 AM, Cong Wang <amwang@redhat.com> wrote:
> Hello, David
>
> I am wondering where are the patches for OVS VXLAN support from Pravin?
> v7 were posted one week ago:
> http://marc.info/?l=linux-netdev&m=137572485116601&w=2
>
> and no one complains about them, so I think they are ready for merge?
>
> But they still do not appear in net-next, nor I can find them in vxlan
> tree of Stephen or openvswitch tree of Jesse. What's more, I even can't
> find them in netdev patchwork [1].

I believe that Stephen is planning on taking the first part of the
series through his VXLAN tree.
