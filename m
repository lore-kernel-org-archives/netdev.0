From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: bcm43xx-softmac broken on 2.6.20-rc2
Date: Tue, 26 Dec 2006 10:24:15 -0600
Message-ID: <45914CAF.1070907@lwfinger.net>
References: <458EA216.7000101@lwfinger.net>
	<20061226154524.GB12583@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: bert hubert <bert.hubert-dxZxOz86jR8sYtaaK7K+xw@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,  torvalds-3NddpPZAyC0@public.gmane.org
In-Reply-To: <20061226154524.GB12583-Q4cIvbmc/GjIwqSPmO0L4w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Sun, Dec 24, 2006 at 09:51:50AM -0600, Larry Finger wrote:
>> This is a heads-up for anyone wishing to use bcm43xx-softmac on Linus's git 
>> tree, which is now at
>> v2.6.20-rc2. There are two serious bugs in that code. Fixes are found below.
> 
> For some reason your patch does not apply to stock 2.6.20-rc2, although I
> don't see why. Applying it by hand makes things compile though, and even
> fixes the problem I mentioned in my previous post:

The patch does not apply because your mailer is breaking the white space and substituting spaces for 
tabs.

Larry
