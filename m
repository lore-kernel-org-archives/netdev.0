From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 0/6 v9] Open vSwitch zercopy upcall optimiziation
Date: Mon, 16 Dec 2013 17:22:10 -0800
Message-ID: <CAEP_g=9gjAoE6S9nuLhx2+rC0kSQ3irMOH_FgpBvOeopO1HcQw@mail.gmail.com>
References: <cover.1386943635.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, fleitner@redhat.com,
	Francesco Fusco <ffusco@redhat.com>, dborkmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:38286 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752099Ab3LQBWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 20:22:31 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so7607201ief.34
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 17:22:30 -0800 (PST)
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 6:22 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Series implementing a zerocopy method for OVS upcall messages. Based
> on top of commit: (''openvswitch: Enable memory mapped Netlink i/o'')

Series applied, thanks.
