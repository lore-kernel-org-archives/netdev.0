From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 20:09:29 -0800
Message-ID: <CA+55aFyyMXWH1cfyB+fUX8jwngjzemiAgoZdKJogs_Pae9m+Xw@mail.gmail.com>
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
	<20150211040245.GD29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150211040245.GD29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 8:02 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Anyway, what userland do you have?

I have regular Fedora 21, nothing special.

I'm *assuming* that the thing that triggers this is that I use disk
encryption on this machine, as that's the only even remotely unusual
thing that isn't just a bog-standard "default install"). The kernel
oops happens basically immediately after I've typed in my decryption
key.

                     Linus
