From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 0/6] e100: driver update
Date: Thu, 28 Apr 2005 19:16:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281911001.29008-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
 
1. Execute tx_timeout task outside the interrupt context
2. Render e100 NAPI state machine to be similar to the non-NAPI one.
3. Synchronize interface link state with e100 poll routine.
4. Fix wake on lan related issues
5. Performance optimizations to e100 Tx path
6. Driver version, white space, comments, device id & other
