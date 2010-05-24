From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer	updates
Date: Mon, 24 May 2010 10:50:44 -0700
Message-ID: <OF4F730E37.19043E17-ON8825772D.00616972-8825772D.0062068B@us.ibm.com>
References: <20100524164205.GA6664@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100524164205.GA6664@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin <mst@redhat.com> wrote on 05/24/2010 09:42:05 AM:
> 
> I see. The logging is still bugg though I think.

Possibly; migration isn't working for me under load even
without mergeable buffers (investigating), so I haven't
yet been able to test wrap w/ logging, but did you see
something specific that's wrong?

                                                +-DLS

