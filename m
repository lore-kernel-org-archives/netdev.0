From: "David S. Miller" <davem@redhat.com>
Subject: Re: Chaotic structure of the net headers?
Date: Wed, 05 Mar 2003 14:39:51 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305.143951.118510613.davem@redhat.com>
References: <20030305225441.GO20423@fs.tum.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@fs.tum.de
In-Reply-To: <20030305225441.GO20423@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Adrian Bunk <bunk@fs.tum.de>
   Date: Wed, 5 Mar 2003 23:54:41 +0100
   
   Two different #define's for the same thing doesn't sound like a good 
   idea?

Required by the ipv6 advanced sockets API I do believe.
