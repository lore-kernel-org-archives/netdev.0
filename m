From: "David S. Miller" <davem@redhat.com>
Subject: Re: oops in tcp_ipv4.c
Date: Thu, 23 Oct 2003 00:38:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031023003805.0f8fb56e.davem@redhat.com>
References: <F483EA17AA200F4CB6812656E66FC68E54F92B@corpusmx5.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Chitrapu_Kishore@emc.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chitrapu_Kishore@emc.com
In-Reply-To: <F483EA17AA200F4CB6812656E66FC68E54F92B@corpusmx5.corp.emc.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Try to reproduce with more recent kernels (2.4.22 would be fine)
and in particular without the vendor patches applied.
