From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 17:46:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF27A48.2090903@pobox.com>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021207.144004.45605764.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Can't the cacheline_aligned attribute be applied to individual
> struct members?  I remember doing this for thread_struct on
> sparc ages ago.


I was hoping someone who knows gcc better than me knew that, and would 
speak up ;-)
