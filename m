From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: net: new warnings in linux-next
Date: Thu, 17 Jul 2008 14:13:20 -0700
Message-ID: <1216329200.6029.20.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-next <linux-next@vger.kernel.org>
To: linux-netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Appears in next-20080717

> net/sysctl_net.c:64:12: warning: incorrect type in initializer (different base types)
> net/sysctl_net.c:64:12:    expected struct ctl_table_set *( *lookup )( ... )
> net/sysctl_net.c:64:12:    got struct list_head *( static [toplevel] *<noident> )( ... )
> net/sysctl_net.c:64: warning: initialization from incompatible pointer type

Cheers,

Harvey
