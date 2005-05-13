From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC: 2.6 patch] make MII no longer user visible
Date: Fri, 13 May 2005 13:00:06 -0400
Message-ID: <4284DD16.8090405@pobox.com>
References: <20050513035257.GC3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050513035257.GC3603@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> MII is a classical example of a helper option no user should ever see.

Incorrect.

It's the classic example of an option that distributors may want to 
build as a module, even if no shipped modules need it, to enable net 
driver development and use in their kernel.

	Jeff
