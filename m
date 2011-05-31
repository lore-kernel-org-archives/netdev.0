From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Tue, 31 May 2011 11:14:27 -0400
Message-ID: <1306854867.11899.31.camel@gandalf.stny.rr.com>
References: <4DE49D52.709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, mingo@elte.hu,
	fweisbec@gmail.com, mathieu.desnoyers@efficios.com,
	tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE49D52.709@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note, the subject should not be "ftrace:", but "net:" or maybe even
"net/tracing", as this really has nothing to do with ftrace code. The
tracepoints are more generic than ftrace.

-- Steve
