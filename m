From: Alex Davis <alex14641@yahoo.com>
Subject: Re: link error building kernel with gcc-3.3
Date: Thu, 15 May 2003 07:56:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515145633.37071.qmail@web40506.mail.yahoo.com>
References: <20030514.224214.42791773.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex14641@yahoo.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, jmorris@intercode.com.au
In-Reply-To: <20030514.224214.42791773.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you push it to 2.4.x as well?

-Alex

--- "David S. Miller" <davem@redhat.com> wrote:
>    From: James Morris <jmorris@intercode.com.au>
>    Date: Thu, 15 May 2003 15:38:15 +1000 (EST)
>    
>    I wonder, does this mean that the compiler failed to inline the function?
>    
>    Removing __inline__ is not the correct solution.
>    
> I already posted what the correct fix is :-)  And this is already
> pushed to 2.5.x

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com
