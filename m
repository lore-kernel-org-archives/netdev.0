From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: KASAN: use-after-free Read in tipc_group_self
Date: Thu, 26 Oct 2017 11:29:30 -0700
Message-ID: <CAM_iQpVQO0iEgbySRPz=JosjLyBdTbRorrhQsGMy2vOjmxwBsQ@mail.gmail.com>
References: <001a113f327c9352cd055c4c63c8@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        syzkaller-bugs@googlegroups.com,
        tipc-discussion@lists.sourceforge.net,
        Ying Xue <ying.xue@windriver.com>
To: syzbot
        <bot+dbf0bb71d5568dfcd9d9cfddad8414c0d4f294c3@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a113f327c9352cd055c4c63c8@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

#syz fix: tipc: fix a dangling pointer
