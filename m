From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] moving from pci to dma
Date: Mon, 12 Jan 2015 10:27:00 -0500
Message-ID: <20150112102700.2aa3b17e@thirdoffive.cmf.nrl.navy.mil>
References: <20150112100239.GA9009@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Quentin Lambert <lambert.quentin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150112100239.GA9009@sloth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There doesn't seem to be a patch for review?

On Mon, 12 Jan 2015 11:02:39 +0100
Quentin Lambert <lambert.quentin@gmail.com> wrote:

> This patch replaces the references to the deprecated pci api with the
> corresponding dma api.
...
> Quentin Lambert (1):
>   atm: remove deprecated use of pci api
> 
>  drivers/atm/eni.c       | 8 +++++---
>  drivers/atm/he.c        | 2 +-
>  drivers/atm/lanai.c     | 9 +++++----
>  drivers/atm/nicstar.c   | 4 ++--
>  drivers/atm/solos-pci.c | 2 +-
>  drivers/atm/zatm.c      | 8 +++++---
>  6 files changed, 19 insertions(+), 14 deletions(-)
> 
