From: Dison River <pwn2river@gmail.com>
Subject: kernel BUG at net/ipv4/tcp_output.c:2748!
Date: Tue, 13 Jun 2017 19:28:09 +0800
Message-ID: <CAJsXRPEOqvOV5bqRn-vE9jaGPZN5+su62AhL4M2i_ogibPpejQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
   I've got the following error report while fuzzing the kernel on
linux-4.11.0-rc3.
