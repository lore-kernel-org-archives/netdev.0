From: Andrew Morton <akpm@osdl.org>
Subject: c99ism in latest linus -bk
Date: Sat, 15 Jan 2005 14:40:10 -0800
Message-ID: <20050115144010.33182075.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

net/sched/cls_api.c: In function `tcf_exts_validate':
net/sched/cls_api.c:489: parse error before `int'
net/sched/cls_api.c:493: `act' undeclared (first use in this function)
net/sched/cls_api.c:493: (Each undeclared identifier is reported only once
net/sched/cls_api.c:493: for each function it appears in.)
net/sched/cls_api.c:494: `err' undeclared (first use in this function)

Someone wanna fix that up please?
