From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] net: socket: Fixed some style issues and
 condensed list of fixes.
Date: Mon, 11 Jun 2012 16:45:07 -0700 (PDT)
Message-ID: <20120611.164507.1289803990715626884.davem@davemloft.net>
References: <1339444359-16248-1-git-send-email-shaw500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shaw500@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339444359-16248-1-git-send-email-shaw500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Shaw <shaw500@gmail.com>
Date: Mon, 11 Jun 2012 20:52:39 +0100

> From: Matthew Shaw <mjshaw@athena.(none)>
> 
> There was an instance of brackets in an if statement that was not
> required, and a number of lines that exceeded 80 chars. The fixes
> list has also been condensed to simply list the people that should
> be credited with various fixes in net/socket.c throughout its
> developement.
> 
> Signed-off-by: Matthew Shaw <shaw500@gmail.com>

I don't see any value in this patch, and the comment fixups don't use
the recommended coding style in the networking, you would need to get
rid of all of that extraneous whitespace between "/* ", "* ", and the
actual test.

But again I really see no value to this change, so I won't be applying
a patch like this, in any form.
