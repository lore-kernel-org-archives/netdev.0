From: "David S. Miller" <davem@redhat.com>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Tue, 17 Sep 2002 18:58:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020917.185801.76605813.davem@redhat.com>
References: <20020918020346.GA2285@samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mbp@samba.org
In-Reply-To: <20020918020346.GA2285@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Which 2.2.x kernel exactly?  You don't specify this.

If it's old, please try to reproduce with more recent 2.2.x
kernels, and even more importantly make sure 2.4.x does not
exhibit this behavior.
