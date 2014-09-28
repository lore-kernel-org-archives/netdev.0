From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: Remove unnessary write over of
 register 11 in rt2800lib.c
Date: Sun, 28 Sep 2014 10:35:32 +0200
Message-ID: <20140928083531.GA2013@redhat.com>
References: <1411852301-26857-1-git-send-email-yocto6@gmail.com>
	<20140928070923.GA2087@redhat.com>
	<CAOJe8K1nkeVjNpNoUBxuJv-YXj3Wr_oH86yR31U7w3Jq5j7oxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicholas Krause <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Denis Kirjanov <kda-u1c8ncikuMvVAZt0uhVF+Ni2O/JbrIOy@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOJe8K1nkeVjNpNoUBxuJv-YXj3Wr_oH86yR31U7w3Jq5j7oxw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com/>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: "users" <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 12:05:30PM +0400, Denis Kirjanov wrote:
> Or someone with the hardware has to test and check that...

... on all possible combinations of channel, bandwidth, signal strength, modulation type, ...

Stanislaw
