From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 14:40:04 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021207.144004.45605764.davem@redhat.com>
References: <3DF2781D.3030209@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <3DF2781D.3030209@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Can't the cacheline_aligned attribute be applied to individual
struct members?  I remember doing this for thread_struct on
sparc ages ago.
