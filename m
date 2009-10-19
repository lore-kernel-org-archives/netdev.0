From: Anirban Sinha <ani@anirban.org>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM enabled
Date: Mon, 19 Oct 2009 09:01:08 -0700
Message-ID: <4ADC8D44.9000804@anirban.org>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local> <20091008.155429.02850661.davem@davemloft.net> <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local> <20091008.175703.83006470.davem@davemloft.net> <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local> <4ADA7EDC.5010402@anirban.org> <4ADB7856.7000803@anirban.org> <20091019121327.GA11423@redhat.com> <4ADC8677.7000607@anirban.org> <20091019153618.GA20967@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Anirban Sinha <asinha@zeugmasystems.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932234AbZJSQGU@vger.kernel.org>
In-Reply-To: <20091019153618.GA20967@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I meant: yes sure it _is legal_ to schedule a work from within a timer
> callback (in fact it is legal from any context).

ok, then that part of the function looks fine.

Ani
