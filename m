From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: unable to handle kernel paging request in vsock_diag_dump
Date: Thu, 26 Oct 2017 11:27:57 -0700
Message-ID: <CAM_iQpUvndPu1gV9OWB=FsEvR-RbgrQ5_RyYshLMsUYT72bkRw@mail.gmail.com>
References: <001a113f99fe969d68055c4c63a3@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org list" <kvm@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>, David Miller <davem@davemloft.net>
To: syzbot
	<bot+d6b6d5e0ac5609c835098f88c893a7bb3cfa0900@syzkaller.appspotmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <001a113f99fe969d68055c4c63a3@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

#syz fix: vsock: always call vsock_init_tables()
