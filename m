From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 11 Feb 2015 04:02:45 +0000
Message-ID: <20150211040245.GD29656@ZenIV.linux.org.uk>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
 <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
 <20150209.205209.1524645061817000265.davem@davemloft.net>
 <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
 <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
 <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
 <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
 <20150211014502.GB29656@ZenIV.linux.org.uk>
 <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
 <CA+55aFxgNOdXonyKXRnKfyLM57_e4EpP+VYr6taUf2Bh5gCg9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxgNOdXonyKXRnKfyLM57_e4EpP+VYr6taUf2Bh5gCg9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 07:58:22PM -0800, Linus Torvalds wrote:
> On Tue, Feb 10, 2015 at 6:01 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Are there no tests for that crypto interface?
> 
> Oh well.
> 
> With the attached, it at least does boot and work for me.

Heh...  Looks like your variant is identical to mine, including the
"let's move the assignment to 'used' past that 'maybe we need to wait'
thing"...

Anyway, what userland do you have?
