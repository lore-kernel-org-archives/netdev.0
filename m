From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v4 0/6] solve deadlock caused by memory allocation with I/O
Date: Wed, 7 Nov 2012 11:37:19 +0800
Message-ID: <CACVXFVM8Z55mHV791TF19kH5J6u_yEXK_=nmu6qk2hiXzn+M9w@mail.gmail.com>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<20121106152303.b1e135ee.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20121106152303.b1e135ee.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 7, 2012 at 7:23 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> It generally looks OK to me.  I have a few comments and I expect to grab
> v5.

Andrew, thanks for your review, and I will prepare -v5 later.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
