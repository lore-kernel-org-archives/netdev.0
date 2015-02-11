From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 11 Feb 2015 14:00:48 +0000
Message-ID: <20150211140048.GF29656@ZenIV.linux.org.uk>
References: <20150209.205209.1524645061817000265.davem@davemloft.net>
 <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
 <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
 <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
 <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
 <20150211014502.GB29656@ZenIV.linux.org.uk>
 <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
 <CA+55aFxgNOdXonyKXRnKfyLM57_e4EpP+VYr6taUf2Bh5gCg9w@mail.gmail.com>
 <20150211040245.GD29656@ZenIV.linux.org.uk>
 <CA+55aFyyMXWH1cfyB+fUX8jwngjzemiAgoZdKJogs_Pae9m+Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyyMXWH1cfyB+fUX8jwngjzemiAgoZdKJogs_Pae9m+Xw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 08:09:29PM -0800, Linus Torvalds wrote:
> On Tue, Feb 10, 2015 at 8:02 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > Anyway, what userland do you have?
> 
> I have regular Fedora 21, nothing special.
> 
> I'm *assuming* that the thing that triggers this is that I use disk
> encryption on this machine, as that's the only even remotely unusual
> thing that isn't just a bog-standard "default install"). The kernel
> oops happens basically immediately after I've typed in my decryption
> key.

Hmm...  Fedora image I've got here has been upgraded from F20, and it's
definitely not configured for disk encryption.  Ought to try fresh
install and throw that thing into the "test on those" pile as well.
Thanks...
