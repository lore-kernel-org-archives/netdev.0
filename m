From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 12 Oct 2016 19:55:04 -0400 (EDT)
Message-ID: <20161012.195504.658773172040030000.davem@davemloft.net>
References: <20161006100055.GA1941@uranus.lan>
        <20161012.015022.2273537782016406180.davem@davemloft.net>
        <20161012065329.GH1941@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
        dsa@cumulusnetworks.com, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: gorcunov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161012065329.GH1941@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 12 Oct 2016 09:53:29 +0300

> I can't rename the field, neither a can use union.

Remind me again what is wrong with using an anonymous union?
