From: Ravish Kumar <ravishk2004@gmail.com>
Subject: Implementing Dynamic Rerouting in Kernel
Date: Thu, 11 May 2017 15:29:36 +0530
Message-ID: <CAEDnJmKWYeEwB=cBKd-cOL+hmxe0U6G7CQ8Mkwc_eP5CpJVmbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Experts,

Need expert advice for the one of the requirement Where in VPN
solution we want to dynaically route the packets to different adapter.
We will manage our own DNS cache and , based on DNS to IP lookup, we
can redirect the packet either to Tun device or to a physical adapter.

Please suggest some design what i need to do.
