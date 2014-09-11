From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Rusty away 18th September -- 11th October
Date: Thu, 11 Sep 2014 13:16:09 -0700
Message-ID: <CA+55aFygkQwbfk9m69ca6pnh6f1AzOiD-gUHBrzqPAmr9H0ouw@mail.gmail.com>
References: <87oaunht4b.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87oaunht4b.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 5:56 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>
>         Probably won't read mail.  Linus, I'll have pull requests early
> next week; if there's anything needed I'm sure Michael Tsirkin can
> handle it.

So according to "normal timing", I would do the 3.17 release about
three weeks from now, Oct 5th, and you would indeed be gone beginning
of the next merge window.

However, Oct 5th is also when I leave for LinuxCon EU, and while I am
willing to sometimes do the second week of the merge window while
traveling, doing the first week is just very impractical for me.
That's when most of the big pull requests get merged, and when I want
to do lots of allmodconfig builds etc, so doing it on the road is just
not worth it.

So right now my options are that
 (a) I can release 3.17 a week early (ie forego a rc7 entirely, and do
the final 3.17 late September) and then just do the second week while
traveling - something I've done many times or
 (b) just delay the merge window until after I come back (and whether
that then delays 3.17 or not is a largely independent issue).

3.17 looks fine so far, and so maybe "skip rc7" is an option. It is
the less likely one, I feel. I won't know until it happens, though.

So having the pull request available early for next merge window is
certainly much appreciated, but it may well be that you'll be back by
the time I actually open it.

I really have been cursed this year timing-wise wrt releases and
travel. I haven't even traveled any more than previous years, but for
some reason my travel dates have just been hitting the release dates
constantly.

> PS.  England and Italy for a holiday; my daughter chose them (somehow I
>      forgot to inform her of the existence of Euro Disney...)

Have fun.

            Linus
